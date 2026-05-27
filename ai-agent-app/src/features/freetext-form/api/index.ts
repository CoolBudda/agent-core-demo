import apiClient from '../../../services/api/client';
import type { FreetextFormData, ValidationResult } from '../../../types';

export async function validateFreetextForm(
  data: FreetextFormData
): Promise<ValidationResult> {
  // sessionId must be present in data
  const response = await apiClient.post(
    '/',
    data
  );
  // If backend returns { result: ... }
  if (response.data && response.data.result) {
    return response.data.result;
  }
  // fallback: assume response.data is ValidationResult
  return response.data;
}
