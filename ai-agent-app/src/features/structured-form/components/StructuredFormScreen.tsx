import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation } from '@tanstack/react-query';
import { structuredFormSchema, type StructuredFormSchema } from '../../../utils/schemas';
import { validateStructuredForm } from '../api';
import type { ValidationResult } from '../../../types';
import ValidationStatus from '../../../shared/components/ValidationStatus';

export default function StructuredFormScreen() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<StructuredFormSchema>({
    resolver: zodResolver(structuredFormSchema),
  });

  const mutation = useMutation<ValidationResult, Error, StructuredFormSchema>({
    mutationFn: validateStructuredForm,
  });

  const onSubmit = (data: StructuredFormSchema) => {
    mutation.mutate(data);
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-start justify-center py-12 px-4">
      <div className="w-full max-w-lg space-y-6">
        <h1 className="text-2xl font-semibold text-gray-900 dark:text-white">
          Structured Form Validation
        </h1>

        <form
          onSubmit={handleSubmit(onSubmit)}
          className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6 space-y-4"
        >
          {/* Name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Name
            </label>
            <input
              {...register('name')}
              placeholder="Full name"
              className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
            {errors.name && (
              <p className="mt-1 text-xs text-red-500">{errors.name.message}</p>
            )}
          </div>

          {/* Email */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Email
            </label>
            <input
              {...register('email')}
              type="email"
              placeholder="you@example.com"
              className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
            {errors.email && (
              <p className="mt-1 text-xs text-red-500">{errors.email.message}</p>
            )}
          </div>

          {/* Phone */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Phone
            </label>
            <input
              {...register('phone')}
              type="tel"
              placeholder="+1 555 000 0000"
              className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
            {errors.phone && (
              <p className="mt-1 text-xs text-red-500">{errors.phone.message}</p>
            )}
          </div>

          {/* Sport */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Sport
            </label>
            <input
              {...register('sport')}
              placeholder="e.g. Basketball"
              className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
            {errors.sport && (
              <p className="mt-1 text-xs text-red-500">{errors.sport.message}</p>
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
