const GITHUB_CLIENT_ID = process.env.NEXT_PUBLIC_GITHUB_CLIENT_ID || "";

export function getGitHubAuthUrl(): string {
  const params = new URLSearchParams({
    client_id: GITHUB_CLIENT_ID,
    redirect_uri: `${window.location.origin}/auth/callback`,
    scope: "read:user user:email",
    state: generateState(),
  });

  return `https://github.com/login/oauth/authorize?${params.toString()}`;
}

function generateState(): string {
  const state = crypto.randomUUID();
  sessionStorage.setItem("oauth_state", state);
  return state;
}

export function validateState(state: string): boolean {
  const savedState = sessionStorage.getItem("oauth_state");
  sessionStorage.removeItem("oauth_state");
  return state === savedState;
}

export function redirectToGitHub(): void {
  window.location.href = getGitHubAuthUrl();
}
