// Supabase Edge Function: auth-redirect
// Handles password reset redirects by capturing hash fragments and passing to app

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "GET, OPTIONS",
  "access-control-max-age": "86400",
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }

  console.log("=== Incoming request to auth-redirect ===");
  
  try {
    // Return HTML page that captures hash fragment and redirects to app
    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Redirecting - ParkMyWhip</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    .container {
      text-align: center;
      padding: 2rem;
    }
    .spinner {
      border: 4px solid rgba(255,255,255,0.3);
      border-top: 4px solid white;
      border-radius: 50%;
      width: 50px;
      height: 50px;
      animation: spin 1s linear infinite;
      margin: 0 auto 1.5rem;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    h1 { margin: 0 0 0.5rem; font-size: 1.5rem; }
    p { margin: 0; opacity: 0.9; }
  </style>
</head>
<body>
  <div class="container">
    <div class="spinner"></div>
    <h1>Redirecting to ParkMyWhip</h1>
    <p>Please wait while we redirect you to the app...</p>
  </div>
  
  <script>
    (function() {
      console.log('Full URL:', window.location.href);
      console.log('Hash fragment:', window.location.hash);
      
      // Get the hash fragment (everything after #)
      const hash = window.location.hash.substring(1); // Remove the # prefix
      
      if (!hash) {
        console.error('No hash fragment found');
        document.querySelector('.container').innerHTML = 
          '<h1>⚠️ Invalid Link</h1><p>This link is invalid or has expired.</p>';
        return;
      }
      
      // Parse hash as query parameters
      const params = new URLSearchParams(hash);
      const accessToken = params.get('access_token');
      const refreshToken = params.get('refresh_token');
      const type = params.get('type');
      
      console.log('Parsed params:', { accessToken: accessToken ? 'present' : 'missing', type });
      
      if (!accessToken) {
        console.error('No access token in hash');
        document.querySelector('.container').innerHTML = 
          '<h1>⚠️ Invalid Link</h1><p>Missing authentication token.</p>';
        return;
      }
      
      // Build deep link URL with all parameters
      const deepLinkUrl = 'parkmywhip://parkmywhip.com?' + 
        'access_token=' + encodeURIComponent(accessToken) +
        '&refresh_token=' + encodeURIComponent(refreshToken || '') +
        '&type=' + encodeURIComponent(type || 'recovery');
      
      console.log('Redirecting to:', deepLinkUrl);
      
      // Redirect to app
      window.location.href = deepLinkUrl;
      
      // Fallback message after 2 seconds
      setTimeout(function() {
        document.querySelector('.container').innerHTML = 
          '<h1>Having trouble?</h1>' +
          '<p>If the app didn\\'t open automatically, please ensure ParkMyWhip is installed.</p>' +
          '<p style="margin-top: 1rem; font-size: 0.9rem;">You can close this window.</p>';
      }, 2000);
    })();
  </script>
</body>
</html>
    `;

    return new Response(html, {
      headers: {
        ...CORS_HEADERS,
        "content-type": "text/html; charset=utf-8",
      },
    });
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      }
    );
  }
});
