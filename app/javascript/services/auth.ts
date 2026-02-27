import http from './http'

const TOKEN_KEY = 'auth_token'

export function getStoredToken(): string | null {
  return localStorage.getItem(TOKEN_KEY)
}

export function storeToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token)
}

export function clearStoredToken(): void {
  localStorage.removeItem(TOKEN_KEY)
}

export async function signIn(email: string, password: string): Promise<string> {
  const response = await http.post('/users/sign_in', {
    user: { email, password },
  })

  const authorization = response.headers['authorization']
  if (!authorization) {
    throw new Error('Token não recebido do servidor')
  }

  const token = authorization.replace('Bearer ', '')
  storeToken(token)
  return token
}

export async function signUp(
  name: string,
  email: string,
  password: string,
  passwordConfirmation: string,
): Promise<void> {
  try {
    await http.post('/users', {
      user: { name, email, password, password_confirmation: passwordConfirmation },
    })
  } catch (e: unknown) {
    if (e instanceof Error && 'response' in e) {
      const response = (e as { response: { data?: { errors?: string[] } } }).response
      if (response.data?.errors?.length) {
        throw new Error(response.data.errors.join('. '))
      }
    }
    throw new Error('Erro ao criar conta')
  }
}

export async function signOut(): Promise<void> {
  try {
    await http.delete('/users/sign_out')
  } finally {
    clearStoredToken()
  }
}
