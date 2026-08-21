export default function handler(req, res) {
  const clientId = process.env.GOOGLE_CLIENT_ID;
  if (!clientId) {
    res.status(500).send("Missing GOOGLE_CLIENT_ID environment variable");
    return;
  }

  const redirectUri = "https://microhelp1.vercel.app/api/callback";
  const state = Math.random().toString(36).slice(2);
  const authorizeUrl =
    `https://accounts.google.com/o/oauth2/v2/auth` +
    `?client_id=${encodeURIComponent(clientId)}` +
    `&redirect_uri=${encodeURIComponent(redirectUri)}` +
    `&response_type=code` +
    `&scope=${encodeURIComponent("openid email profile")}` +
    `&state=${encodeURIComponent(state)}`;

  res.writeHead(302, { Location: authorizeUrl });
  res.end();
}
