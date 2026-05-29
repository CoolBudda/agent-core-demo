import type { ValidationResult } from '../../types';

interface Props {
  isPending: boolean;
  isError: boolean;
  error: Error | null;
  result?: ValidationResult;
}

export default function ValidationStatus({ isPending, isError, error, result }: Props) {
  const getStatusClass = () => {
    if (!result) return 'text-gray-500 dark:text-gray-400';
    if (result.status === 'success') return 'text-green-700 dark:text-green-400';
    if (result.status === 'missing') return 'text-red-700 dark:text-red-400';
    return 'text-yellow-700 dark:text-yellow-400';
  };

  const getDisplayText = () => {
    if (isPending) return 'Sending request to validation service…';
    if (isError) return `Error: ${error?.message ?? 'Unknown error occurred'}`;
    if (!result) return 'Submit the form above to see the validation result here.';
    const lines = [`Status: ${result.status.toUpperCase()}`, `Message: ${result.message}`];
    if (result.details?.length) {
      console.log('details type:', typeof result.details);
      console.log('Validation details:', result.details);
      lines.push('', 'Details:', ...result.details.map((d) => `  • ${d}`));
    }
    return lines.join('\n');
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
      <h2 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        Validation Result
      </h2>
      <textarea
        readOnly
        value={getDisplayText()}
        rows={6}
        className={`w-full resize-none rounded-md border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-900 px-3 py-2 text-sm font-mono focus:outline-none ${getStatusClass()}`}
      />
    </div>
  );
}
