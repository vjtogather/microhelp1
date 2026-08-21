export default async function handler(req, res) {
  const { code } = req.query;
  const clientId = process.env.GOOGLE_CLIENT_ID;
  const clientSecret = process.env.GOOGLE_CLIENT_SECRET;
  const githubToken = process.env.GITHUB_PAT;
  const allowedEmails = (process.env.ALLOWED_EMAILS || "")
    .split(",")
    .map((e) => e.trim().toLowerCase())
    .filter(Boolean);

  if (!code) {
    res.status(400).send("Missing code parameter");
    return;
  }
  if (!clientId || !clientSecret || !githubToken) {
    res.status(500).send("Missing GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET / GITHUB_PAT environment variables");
    return;
  }

  const redirectUri = "https://microhelp1.vercel.app/api/callback";

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      code,
      client_id: clientId,
      client_secret: clientSecret,
      redirect_uri: redirectUri,
      grant_type: "authorization_code",
    }),
  });
  const tokenData = await tokenRes.json();

  if (tokenData.error) {
    res.status(400).send(`Google OAuth error: ${tokenData.error_description || tokenData.error}`);
    return;
  }

  const infoRes = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${tokenData.id_token}`);
  const info = await infoRes.json();

  if (!info.email || info.email_verified !== "true") {
    res.status(403).send("Google account email not verified.");
    return;
  }

  if (allowedEmails.length && !allowedEmails.includes(info.email.toLowerCase())) {
    res.status(403).send(`Access denied for ${info.email}. This email is not authorized to edit this site.`);
    return;
  }

  const payload = JSON.stringify({ token: githubToken, provider: "github" });

  const html = `<!doctype html><html><body>
<script>
(function() {
  function receiveMessage(e) {
    window.opener.postMessage(
      'authorization:github:success:${payload}',
      e.origin
    );
    window.removeEventListener("message", receiveMessage, false);
  }
  window.addEventListener("message", receiveMessage, false);
  window.opener.postMessage("authorizing:github", "*");
})();
</script>
</body></html>`;

  res.setHeader("Content-Type", "text/html");
  res.status(200).send(html);
}
