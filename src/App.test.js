import { render, screen } from '@testing-library/react';
import App from './App';

test('renders learn react link', () => {
  // Render the App component
  render(<App />);

  // Check if the "Learn React" link is present in the document
  const linkElement = screen.getByText(/learn react/i);
  expect(linkElement).toBeInTheDocument();
});
test('renders learn react link1', () => {
  // Render the App component
  render(<App />);

  // Check if the "Learn React" link is present in the document
  const linkElement = screen.getByText(/learn react/i);
  expect(linkElement).toBeInTheDocument();
  // expect(0).toBe(1);
});
