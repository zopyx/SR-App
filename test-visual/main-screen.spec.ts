import { test, expect } from '@playwright/test';

test.describe('Main Screen Visual Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    // Wait for the app to fully load
    await page.waitForSelector('.player-container');
    // Wait for animations to settle
    await page.waitForTimeout(500);
  });

  test('main screen - default view', async ({ page }) => {
    // Set viewport to match app window size
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Take screenshot of the full page
    await expect(page).toHaveScreenshot('main-screen-default.png', {
      fullPage: true,
      threshold: 0.2,
    });
  });

  test('main screen - station selector open', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Click to open station selector
    await page.click('.station-selector-toggle');
    await page.waitForTimeout(300);
    
    await expect(page).toHaveScreenshot('main-screen-selector-open.png', {
      fullPage: true,
      threshold: 0.2,
    });
  });

  test('main screen - hover states', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Hover over play button
    await page.hover('.logo-wrapper');
    await page.waitForTimeout(200);
    
    await expect(page).toHaveScreenshot('main-screen-hover-play.png', {
      fullPage: true,
      threshold: 0.2,
    });
  });

  test('main screen - no visual regression', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Check key elements are visible and positioned correctly
    const stationSelector = page.locator('.station-selector-toggle');
    await expect(stationSelector).toBeVisible();
    
    const logo = page.locator('.logo-wrapper');
    await expect(logo).toBeVisible();
    
    const volumeControl = page.locator('.volume-control');
    await expect(volumeControl).toBeVisible();
    
    const footer = page.locator('.app-footer');
    await expect(footer).toBeVisible();
    
    // Check no elements overflow the window
    const body = page.locator('body');
    const bodyBox = await body.boundingBox();
    const htmlBox = await page.locator('html').boundingBox();
    
    expect(bodyBox?.height).toBeLessThanOrEqual(400);
    expect(bodyBox?.width).toBeLessThanOrEqual(320);
  });
});
