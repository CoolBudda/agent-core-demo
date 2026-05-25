import { Link, useLocation } from 'react-router-dom';

export default function MainLayout({ children }: { children: React.ReactNode }) {
  const { pathname } = useLocation();

  const navItems = [
    { path: '/', label: 'Structured Form' },
    { path: '/freetext', label: 'Free-text Form' },
  ];

  return (
    <div className="min-h-screen flex flex-col bg-gray-50 dark:bg-gray-900">
      <nav className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
        <div className="max-w-5xl mx-auto px-4 flex items-center h-14 gap-6">
          <span className="font-semibold text-gray-900 dark:text-white text-sm tracking-tight">
            AI Agent App
          </span>
          <div className="flex gap-1">
            {navItems.map(({ path, label }) => (
              <Link
                key={path}
                to={path}
                className={`px-3 py-1.5 rounded-md text-sm font-medium transition-colors ${
                  pathname === path
                    ? 'bg-indigo-50 text-indigo-700 dark:bg-indigo-900/40 dark:text-indigo-300'
                    : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white'
                }`}
              >
                {label}
              </Link>
            ))}
          </div>
        </div>
      </nav>
      <main className="flex-1">{children}</main>
    </div>
  );
}
