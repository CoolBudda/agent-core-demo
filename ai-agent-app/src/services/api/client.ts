import axios from 'axios';

// const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? '/api';

const API_BASE_URL = "https://kkhop5fqvzd2qskuwe5ratm33a0fklyj.lambda-url.us-east-1.on.aws/"
// lambda: user-registration-validation-br-ag-1d368

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
});

apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token');
    }
    return Promise.reject(error);
  }
);

export default apiClient;
