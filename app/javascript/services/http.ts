import axios from 'axios'
import { getStoredToken, clearStoredToken } from './auth'

const http = axios.create({
  baseURL: '',
  timeout: 5000,
  headers: {
    'Content-Type': 'application/json',
  },
})

http.interceptors.request.use((config) => {
  const token = getStoredToken()
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  const locale = localStorage.getItem('locale') || 'en'
  config.headers['Accept-Language'] = locale === 'pt_BR' ? 'pt-BR' : 'en'
  return config
})

http.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      clearStoredToken()
    }
    return Promise.reject(error)
  },
)

export default http
