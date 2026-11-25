import java.io.InputStream;
import java.nio.file.Path;
import java.security.CodeSigner;
import java.security.MessageDigest;
import java.security.cert.X509Certificate;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.Locale;
import java.util.Set;
import java.util.jar.JarFile;
import javax.naming.ldap.LdapName;

/** Verify every AAB entry with the JDK's JAR verifier, not certificate text alone. */
public class VerifyAndroidBundle {
  public static void main(String[] args) throws Exception {
    if (args.length != 3) throw new IllegalArgumentException("aab expected-sha256|- development|store|distribution");
    boolean distribution = args[2].equals("distribution");
    boolean store = args[2].equals("store");
    if (!distribution && !store && !args[2].equals("development")) throw new IllegalArgumentException("Unknown signing mode");
    String expected = args[1].replace(":", "").toLowerCase(Locale.ROOT);
    if (!expected.equals("-") && !expected.matches("[0-9a-f]{64}")) throw new IllegalArgumentException("Invalid expected SHA256");
    if (distribution && expected.equals("-")) throw new IllegalArgumentException("Distribution needs expected upload certificate SHA256");
    Set<String> fingerprints = new HashSet<>();
    int signedEntries = 0;
    try (JarFile jar = new JarFile(Path.of(args[0]).toFile(), true)) {
      if (jar.getManifest() == null || jar.getEntry("BundleConfig.pb") == null
          || jar.getEntry("base/manifest/AndroidManifest.xml") == null) {
        throw new SecurityException("Missing signed bundle structure");
      }
      Set<String> names = new HashSet<>();
      var entries = jar.entries();
      while (entries.hasMoreElements()) {
        var entry = entries.nextElement();
        if (!names.add(entry.getName())) throw new SecurityException("Duplicate bundle entry: " + entry.getName());
        String name = entry.getName().toUpperCase(Locale.ROOT);
        if (entry.isDirectory() || name.equals("META-INF/MANIFEST.MF")
            || name.matches("META-INF/[^/]+\\.(SF|RSA|DSA|EC)")) continue;
        // Reading to EOF is essential: it triggers digest and signature checks.
        try (InputStream stream = jar.getInputStream(entry)) {
          stream.transferTo(java.io.OutputStream.nullOutputStream());
        }
        CodeSigner[] signers = entry.getCodeSigners();
        if (signers == null || signers.length != 1) {
          throw new SecurityException("Unsigned or ambiguously signed entry: " + entry.getName());
        }
        X509Certificate certificate = (X509Certificate) signers[0].getSignerCertPath().getCertificates().get(0);
        certificate.checkValidity();
        String fingerprint = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(certificate.getEncoded()));
        if (!expected.equals("-") && !expected.equals(fingerprint)) throw new SecurityException("Wrong AAB upload certificate");
        if (fingerprints.add(fingerprint) && (store || distribution)) {
          for (var rdn : new LdapName(certificate.getSubjectX500Principal().getName()).getRdns()) {
            var commonName = rdn.toAttributes().get("CN");
            if (commonName != null && "Android Debug".equalsIgnoreCase(commonName.get().toString())) {
              throw new SecurityException("Android Debug certificate cannot sign a store AAB");
            }
          }
        }
        signedEntries++;
      }
    }
    if (signedEntries == 0 || fingerprints.size() != 1) throw new SecurityException("Inconsistent or empty signed bundle");
    System.out.println("{\"certificate_sha256\":\"" + fingerprints.iterator().next()
        + "\",\"signed_entries\":" + signedEntries + "}");
  }
}
