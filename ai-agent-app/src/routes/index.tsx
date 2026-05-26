import { lazy, Suspense } from 'react';
import { createBrowserRouter } from 'react-router-dom';
import MainLayout from '../layouts/MainLayout';

const FreetextFormScreen = lazy(
  () => import('../features/freetext-form/components/FreetextFormScreen')
);

const Loading = () => (
  <div className="flex items-center justify-center min-h-screen text-gray-400 text-sm">
    Loading…
  </div>
);

export const router = createBrowserRouter([
  {
    path: '/',
    element: (
      <MainLayout>
        <Suspense fallback={<Loading />}>
          <FreetextFormScreen />
        </Suspense>
      </MainLayout>
    ),
  },
]);
