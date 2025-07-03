// @ts-check

// This is a basic test scaffold using Playwright.

// This file is the test spec to verify that the website counter API is functioning correctly.
// It hits the counter API exactly as the website does and verifies that the counter increments by 1
// Just as expected.
// For the "page" it is incrementing, we are using 'test-page' as a default value
// The API code in Lambda will create any counter entires that do not already exist, so any value can be used.


const { test, expect } = require('@playwright/test');

test('Website counter increments correctly', async ({ request }) => {
  const page_name = 'test-page'; // You can change this to anything
  const endpoint = `/website_counter?page_name=${page_name}`; // Adjust path if needed

  // First request
  const response1 = await request.get(endpoint);
  expect(response1.ok()).toBeTruthy();

  const body1 = await response1.text();
  const count1 = parseInt(body1, 10);

  expect(Number.isNaN(count1)).toBeFalsy();
  console.log(`First count: ${count1}`);

  // Second request
  const response2 = await request.get(endpoint);
  expect(response2.ok()).toBeTruthy();

  const body2 = await response2.text();
  const count2 = parseInt(body2, 10);

  expect(Number.isNaN(count2)).toBeFalsy();
  console.log(`Second count: ${count2}`);

  // The second value should be one higher
  expect(count2).toBe(count1 + 1);
});
