import { test, expect } from '@playwright/test';

test.describe('Compact Mode Visual Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('.player-container');
    await page.waitForTimeout(500);
  });

  test('compact mode - minimized view', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Note: Compact toggle is hidden by default in CSS, so this test
    // verifies the default layout is visually correct
    
    await expect(page).toHaveScreenshot('compact-mode-default.png', {
      fullPage: true,
      threshold: 0.2,
    });
  });

  test('compact mode - elements visibility', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Essential elements should be visible
    await expect(page.locator('.station-selector-toggle')).toBeVisible();
    await expect(page.locator('.logo-wrapper')).toBeVisible();
    await expect(page.locator('.volume-control')).toBeVisible();
    
    // Check layout is balanced
    const playerContainer = page.locator('.player-container');
    const containerBox = await playerContainer.boundingBox();
    
    // Container should be centered vertically
    expect(containerBox?.y).toBeGreaterThan(20);
    expect(containerBox?.y + (containerBox?.height || 0)).toBeLessThan(380);
  });
});

test.describe('Responsive Layout Tests', () => {
  test('layout at minimum size', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    await page.goto('/');
    await page.waitForSelector('.player-container');
    await page.waitForTimeout(500);
    
    // Take baseline screenshot
    await expect(page).toHaveScreenshot('responsive-320x400.png', {
      fullPage: true,
      threshold: 0.2,
    });
    
    // Check no horizontal scrollbar
    const hasHorizontalScrollbar = await page.evaluate(() => {
      return document.documentElement.scrollWidth > document.documentElement.clientWidth;
    });
    expect(hasHorizontalScrollbar).toBe(false);
    
    // Check no vertical scrollbar (content should fit)
    const hasVerticalScrollbar = await page.evaluate(() => {
      return document.documentElement.scrollHeight > document.documentElement.clientHeight;
    });
    expect(hasVerticalScrollbar).toBe(false);
  });

  test('info button position', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    const infoButton = page.locator('.info-button');
    const buttonBox = await infoButton.boundingBox();
    
    // Should be in top-right corner
    expect(buttonBox?.x).toBeGreaterThan(280); // Right side
    expect(buttonBox?.y).toBeLessThan(40); // Top area
  });

  test('station selector position', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    const selector = page.locator('.station-selector-toggle');
    const selectorBox = await selector.boundingBox();
    
    // Should be near top but below traffic lights
    expect(selectorBox?.y).toBeGreaterThan(20);
    expect(selectorBox?.y).toBeLessThan(60);
    
    // Should be horizontally centered
    const centerX = (selectorBox?.x || 0) + (selectorBox?.width || 0) / 2;
    expect(centerX).toBeCloseTo(160, 30); // Center of 320px width
  });
});
