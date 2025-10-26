# Cloudflare CDN Setup Guide

This guide explains how to set up Cloudflare Pages to serve your Flutter component library through a CDN, similar to how shadcn/ui serves components from `ui.shadcn.com`.

## Overview

The Flutter component library will be deployed to Cloudflare Pages, providing:
- 🌐 Global CDN distribution
- ⚡ Instant cache invalidation
- 📊 Analytics and performance monitoring
- 🔒 HTTPS and security features
- 🔄 Automatic deployments from GitHub

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions  │───▶│ Cloudflare CDN  │
│                 │    │                  │    │                 │
│ • Components    │    │ • Build Registry │    │ • Registry URL  │
│ • Registry      │    │ • Validate       │    │ • Components    │
│ • Scripts       │    │ • Deploy         │    │ • Global Cache  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         ▲                                                    │
         │                                                    ▼
         │                                            ┌─────────────────┐
         └──────────────────────────────────────────────│     CLI        │
                                                      │                 │
                                                      │ • Fetch Registry│
                                                      │ • Download      │
                                                      │ • Cache         │
                                                      └─────────────────┘
```

## Step 1: Cloudflare Account Setup

### 1.1 Create Cloudflare Account

1. Visit [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Sign up for a free account
3. Verify your email address

### 1.2 Choose Your Plan

For a component library, the **Free plan** is sufficient:
- ✅ 1 project
- ✅ 500 builds/month
- ✅ Unlimited bandwidth
- ✅ Global CDN
- ✅ Custom domain support

## Step 2: Cloudflare Pages Project Setup

### 2.1 Create Pages Project

1. Go to **Pages** in the Cloudflare dashboard
2. Click **"Create a project"**
3. Select **"Upload assets"** (for initial setup)
4. Upload your `dist/` folder:
   ```bash
   # First build your registry
   dart run build_registry.dart

   # Create ZIP of dist folder
   cd dist
   zip -r ../flutter-components.zip .
   ```
5. Upload `flutter-components.zip`
6. Project name: `my-custom-component` (or your preferred name)
7. Deployment will complete, giving you a URL like: `https://my-custom-component.pages.dev`

### 2.2 Project Configuration

After deployment, configure your project:

1. Go to project settings:
   - **Domain**: Use default or connect custom domain
   - **Builds**: Disable automatic builds (we use GitHub Actions)
   - **Environment variables**: Add if needed

## Step 3: API Token and Account ID

### 3.1 Get Account ID

1. In Cloudflare dashboard
2. Click **"Workers & Pages"** in sidebar
3. Look at the URL - it contains your account ID:
   ```
   https://dash.cloudflare.com/[ACCOUNT_ID]/pages
   ```

### 3.2 Create API Token

1. Go to **"Manage Account" → "API Tokens"**
2. Click **"Create Token"**
3. Use **"Custom token"** template
4. Configure with these permissions:

| Permission | Scope | Value |
|------------|-------|-------|
| Account | Cloudflare Pages:Edit | All zones |
| Account | Account Settings:Read | All zones |

5. Set **TTL** to **Custom** with long expiry
6. Click **"Continue to summary"** → **"Create Token"**
7. Copy the token immediately (you won't see it again)

## Step 4: GitHub Repository Configuration

### 4.1 Add Secrets to GitHub

In your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `CLOUDFLARE_API_TOKEN` | Your API token from step 3.2 |
| `CLOUDFLARE_ACCOUNT_ID` | Your account ID from step 3.1 |

### 4.2 Verify Workflow Configuration

The `.github/workflows/ci-cd.yml` file is already configured with:

- **Trigger**: Push to `main` branch and tags (`v*.*.*`)
- **Build process**: Runs `dart run build_registry.dart`
- **Deployment**: Uses `cloudflare/pages-action@v1`
- **Validation**: Registry validation and integrity checks

## Step 5: Testing the Setup

### 5.1 Initial Deployment

1. Push your code to trigger the workflow:
   ```bash
   git add .
   git commit -m "feat: Add Cloudflare Pages deployment setup"
   git push origin main
   ```

2. Monitor the workflow in **Actions** tab
3. Check deployment in Cloudflare dashboard

### 5.2 Verify CDN URLs

After successful deployment, verify these URLs work:

```bash
# Registry endpoint
curl https://my-custom-component.pages.dev/registry.json

# Individual component
curl https://my-custom-component.pages.dev/components/button.dart

# Test with your custom domain if configured
curl https://components.yourdomain.com/registry.json
```

### 5.3 Cache Headers

Cloudflare Pages automatically sets optimal cache headers:
- **Static files**: 1 year (immutable)
- **HTML/JSON**: 4 hours (revalidated)
- **Custom headers**: Can be added via `_headers` file

## Step 6: Custom Domain (Optional)

### 6.1 Connect Custom Domain

1. In Cloudflare dashboard, go to your Pages project
2. Click **"Custom domains"**
3. Add your domain (e.g., `components.yourdomain.com`)
4. Update your DNS:
   - CNAME record pointing to `pages.dev`
   - Or follow Cloudflare's instructions

### 6.2 Update Registry URLs

Update `build_registry.dart` to use your custom domain:

```dart
return {
  'registry': {
    'name': 'my_custom_component',
    'version': _version,
    'homepage': 'https://components.yourdomain.com',
    // ...
  },
};
```

## Step 7: CLI Integration

### 7.1 How Your CLI Should Fetch Components

Your CLI should fetch components using this flow:

```dart
// 1. Fetch registry from CDN
final response = await http.get(
  Uri.parse('https://my-custom-component.pages.dev/registry.json')
);
final registry = jsonDecode(response.body);

// 2. Parse components
final components = registry['components'] as Map<String, dynamic>;

// 3. Download specific component
if (components.containsKey('button')) {
  final buttonInfo = components['button'];
  final componentUrl = 'https://my-custom-component.pages.dev/${buttonInfo['path']}';

  // Download component
  final componentResponse = await http.get(Uri.parse(componentUrl));

  // Verify checksum
  final downloadedChecksum = sha256.convert(componentResponse.bodyBytes).toString();
  if (downloadedChecksum != buttonInfo['checksum']) {
    throw Exception('Checksum verification failed');
  }

  // Save to local project
  await File('lib/components/button.dart').writeAsString(componentResponse.body);
}
```

### 7.2 Error Handling and Fallbacks

Implement robust error handling:

```dart
class ComponentDownloader {
  final List<String> cdnUrls = [
    'https://my-custom-component.pages.dev',
    'https://backup-cdn.yourdomain.com',
    'https://github.com/yourorg/my_custom_component/raw/main/dist'
  ];

  Future<String> downloadComponent(String name) async {
    for (final cdnUrl in cdnUrls) {
      try {
        // Try to fetch registry
        final registry = await fetchRegistry(cdnUrl);

        if (registry['components'].containsKey(name)) {
          final component = registry['components'][name];
          final componentUrl = '$cdnUrl/${component['path']}';

          final response = await http.get(Uri.parse(componentUrl));
          if (response.statusCode == 200) {
            return response.body;
          }
        }
      } catch (e) {
        print('Failed to fetch from $cdnUrl: $e');
        continue;
      }
    }

    throw Exception('Failed to download component: $name');
  }
}
```

## Step 8: Monitoring and Analytics

### 8.1 Cloudflare Analytics

1. Go to your Pages project in dashboard
2. Click **"Analytics"** tab
3. Monitor:
   - **Requests**: Total CDN requests
   - **Bandwidth**: Data transfer usage
   - **Cache hit ratio**: Performance optimization
   - **Popular files**: Most downloaded components

### 8.2 Performance Optimization

Add `_headers` file in `dist/` for custom caching:

```
# dist/_headers
/components/*
  Cache-Control: public, max-age=31536000, immutable

/registry.json
  Cache-Control: public, max-age=3600, must-revalidate

/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
```

## Step 9: Advanced Features

### 9.1 Versioning Strategy

Implement semantic versioning with URL patterns:

```
# Latest version
https://my-custom-component.pages.dev/registry.json

# Specific version
https://my-custom-component.pages.dev/v1.0.0/registry.json

# Versioned components
https://my-custom-component.pages.dev/v1.0.0/components/button.dart
```

### 9.2 Edge Functions (Optional)

For dynamic features like:
- Component search/filtering
- Usage analytics
- A/B testing
- Custom authentication

Create `functions/` directory:

```javascript
// functions/_middleware.js
export async function onRequest(context) {
  const url = new URL(context.request.url);

  // Log component downloads
  if (url.pathname.startsWith('/components/')) {
    console.log(`Component downloaded: ${url.pathname}`);
  }

  return context.next();
}
```

## Step 10: Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **API Token Error** | Verify token has Pages:Edit permission |
| **Build Failures** | Check workflow logs, ensure `dart run build_registry.dart` succeeds |
| **404 Errors** | Verify file paths in registry.json match actual file locations |
| **Cache Issues** | Purge cache in Cloudflare dashboard or wait for automatic invalidation |

### Debugging Commands

```bash
# Test CDN availability
curl -I https://my-custom-component.pages.dev/registry.json

# Check response headers
curl -v https://my-custom-component.pages.dev/components/button.dart

# Verify JSON structure
curl https://my-custom-component.pages.dev/registry.json | jq .

# Test locally
dart run build_registry.dart
python3 -m http.server 8000 --directory dist
# Then visit http://localhost:8000/registry.json
```

## Security Considerations

1. **API Token Security**:
   - Use GitHub repository secrets
   - Rotate tokens regularly
   - Principle of least privilege

2. **Content Security**:
   - No sensitive data in components
   - Verify checksums before use
   - Use HTTPS for all requests

3. **Rate Limiting**:
   - Cloudflare provides DDoS protection
   - Monitor for abuse patterns
   - Implement client-side rate limiting

## Migration from Existing Setup

If you're migrating from another CDN:

1. **Gradual Migration**:
   ```bash
   # Add secondary CDN in CLI
   cdnUrls: [
     'https://old-cdn.com',  # Fallback
     'https://my-custom-component.pages.dev'  # Primary
   ]
   ```

2. **DNS Migration**:
   - Lower TTL on existing records
   - Update to point to Cloudflare
   - Monitor for issues
   - Decommission old CDN

## Cost Analysis

### Free Tier Benefits (Your Case)
- ✅ **0-100,000 requests/day**: Free
- ✅ **Unlimited bandwidth**: Free
- ✅ **Global CDN**: Free
- ✅ **SSL certificates**: Free
- ✅ **DDoS protection**: Free

### When to Upgrade
- > 500 builds/month
- Custom analytics needs
- Advanced edge functions
- Dedicated support

## Best Practices

1. **Build Optimization**:
   - Minimize component file sizes
   - Use efficient file compression
   - Optimize import statements

2. **Cache Strategy**:
   - Long cache for static components
   - Shorter cache for registry
   - Cache invalidation on updates

3. **Monitoring**:
   - Set up alerts for build failures
   - Monitor CDN performance
   - Track component usage patterns

4. **Documentation**:
   - Keep API documentation current
   - Provide migration guides
   - Include troubleshooting tips

## Conclusion

Your Flutter component library is now production-ready with:
- 🌐 **Global CDN distribution** via Cloudflare Pages
- 🔄 **Automated deployments** with GitHub Actions
- 🔐 **Security** with checksums and HTTPS
- 📊 **Monitoring** and analytics
- 💰 **Cost-effective** (free tier covers typical usage)

The setup provides a robust foundation for serving components to developers worldwide, with the same reliability and performance as major component libraries like shadcn/ui.

For any issues or questions, refer to:
- [Cloudflare Pages Documentation](https://developers.cloudflare.com/pages/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- The troubleshooting section above