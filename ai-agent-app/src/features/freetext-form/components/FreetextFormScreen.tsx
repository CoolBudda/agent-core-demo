import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation } from '@tanstack/react-query';
import { freetextFormSchema, type FreetextFormSchema } from '../../../utils/schemas';
import { validateFreetextForm } from '../api';
import type { ValidationResult } from '../../../types';
import ValidationStatus from '../../../shared/components/ValidationStatus';

export default function FreetextFormScreen() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FreetextFormSchema>({
    resolver: zodResolver(freetextFormSchema),
  });

  const mutation = useMutation<ValidationResult, Error, FreetextFormSchema>({
    mutationFn: validateFreetextForm,
  });

  const onSubmit = (data: FreetextFormSchema) => {
    mutation.mutate(data);
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-start justify-center py-12 px-4">
      <div className="w-full max-w-lg space-y-6">
        <h1 className="text-2xl font-semibold text-gray-900 dark:text-white">
          Free-text Form Validation
        </h1>
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Enter all your information as a single string (e.g. "John Doe, john@example.com, +1-555-0000, Basketball")
        </p>

        <form
          onSubmit={handleSubmit(onSubmit)}
          className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6 space-y-4"
        >
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Your Information
            </label>
            <textarea
              {...register('rawInput')}
              rows={5}
              placeholder="John Doe, john@example.com, +1 555 000 0000, Basketball"
              className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none"
            />
            {errors.rawInput && (
              <p className="mt-1 text-xs text-red-500">{errors.rawInput.message}</p>
            )}
          </div>

          <button
            type="submit"
            disabled={mutation.isPending}
            className="w-full rounded-md bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white text-sm font-medium py-2 transition-colors"
          >
            {mutation.isPending ? 'Validating…' : 'Validate'}
          </button>
        </form>

        <ValidationStatus
          isPending={mutation.isPending}
          isError={mutation.isError}
          error={mutation.error}
          result={mutation.data}
        />
      </div>
    </div>
  );
}
