import { useState, type FormEvent } from 'react';

interface FormData {
  user: string;
  password: string;
  phone: string;
  sport: string;
}

interface SubmitState {
  loading: boolean;
  success: boolean | null;
  message: string;
}

const SPORTS = ['Basketball', 'Football', 'Soccer', 'Tennis', 'Swimming', 'Running', 'Cycling', 'Baseball', 'Golf', 'Other'];

const LAMBDA_URL = import.meta.env.VITE_LAMBDA_URL as string;

export function RegistrationForm() {
  const [formData, setFormData] = useState<FormData>({
    user: '',
    password: '',
    phone: '',
    sport: '',
  });

  const [submitState, setSubmitState] = useState<SubmitState>({
    loading: false,
    success: null,
    message: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setSubmitState({ loading: true, success: null, message: '' });

    try {
      const response = await fetch(LAMBDA_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error(`Server error: ${response.status}`);
      }

      const data = await response.json();
      setSubmitState({
        loading: false,
        success: true,
        message: data.message ?? 'Registration successful! AgentCore is processing your request.',
      });
      setFormData({ user: '', password: '', phone: '', sport: '' });
    } catch (err) {
      setSubmitState({
        loading: false,
        success: false,
        message: err instanceof Error ? err.message : 'An unexpected error occurred.',
      });
    }
  };

  return (
    <div className="form-container">
      <h1>AgentCore Registration</h1>
      <p className="subtitle">Fill in your details to get started with AgentCore processing.</p>

      <form onSubmit={handleSubmit} noValidate>
        <div className="form-group">
          <label htmlFor="user">Username</label>
          <input
            id="user"
            type="text"
            name="user"
            value={formData.user}
            onChange={handleChange}
            placeholder="Enter your username"
            required
            minLength={3}
            autoComplete="username"
          />
        </div>

        <div className="form-group">
          <label htmlFor="password">Password</label>
          <input
            id="password"
            type="password"
            name="password"
            value={formData.password}
            onChange={handleChange}
            placeholder="Enter your password"
            required
            minLength={8}
            autoComplete="new-password"
          />
        </div>

        <div className="form-group">
          <label htmlFor="phone">Phone Number</label>
          <input
            id="phone"
            type="tel"
            name="phone"
            value={formData.phone}
            onChange={handleChange}
            placeholder="+1 (555) 000-0000"
            required
            pattern="^\+?[\d\s\-().]{7,20}$"
          />
        </div>

        <div className="form-group">
          <label htmlFor="sport">Favourite Sport</label>
          <select
            id="sport"
            name="sport"
            value={formData.sport}
            onChange={handleChange}
            required
          >
            <option value="" disabled>Select a sport…</option>
            {SPORTS.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
        </div>

        {submitState.message && (
          <div className={`alert ${submitState.success ? 'alert-success' : 'alert-error'}`}>
            {submitState.message}
          </div>
        )}

        <button type="submit" disabled={submitState.loading} className="submit-btn">
          {submitState.loading ? 'Submitting…' : 'Submit'}
        </button>
      </form>
    </div>
  );
}
