// Example TypeScript file with a GitHub API key (for testing purposes)

const config = {
  apiUrl: 'https://api.github.com',
  // WARNING: This is a test API key - should be blocked by the hook
  apiKey: 'gh_api_1234567890abcdef12345678',
  userAgent: 'MyApp/1.0'
};

export function makeGitHubRequest(endpoint: string) {
  return fetch(`${config.apiUrl}${endpoint}`, {
    headers: {
      'Authorization': `token ${config.apiKey}`,
      'User-Agent': config.userAgent
    }
  });
}
