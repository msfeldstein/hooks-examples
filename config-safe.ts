// Example TypeScript file with api key as env var

const config = {
    apiUrl: 'https://api.github.com',
    // @ts-ignore
    apiKey: process.env.GITHUB_API_KEY,
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
  