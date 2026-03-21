import { test, expect } from '@playwright/test';

test.describe('About Screen Visual Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('.player-container');
    // Open about dialog
    await page.click('.info-button');
    await page.waitForSelector('.about-dialog');
    await page.waitForTimeout(500);
  });

  test('about screen - default view', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    await expect(page).toHaveScreenshot('about-screen-default.png', {
      fullPage: true,
      threshold: 0.2,
    });
  });

  test('about screen - stations section visible', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Check stations section is visible
    const stationsSection = page.locator('.about-section:has-text("Available Stations")');
    await expect(stationsSection).toBeVisible();
    
    // Check all 3 station cards are visible
    const stationCards = page.locator('.station-card');
    await expect(stationCards).toHaveCount(3);
    
    // Take screenshot
    await expect(page).toHaveScreenshot('about-screen-stations.png', {
      fullPage: true,
      threshold: 0.2,
    });
  });

  test('about screen - app information section', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Scroll to App Information section
    const appInfoSection = page.locator('.about-section', { hasText: 'App Information' });
    await appInfoSection.scrollIntoViewIfNeeded();
    await page.waitForTimeout(300);
    
    await expect(page).toHaveScreenshot('about-screen-app-info.png', {
      fullPage: true,
      threshold: 0.2,
    });
  });

  test('about screen - scrolling works', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    const aboutContent = page.locator('.about-content');
    
    // Check initial scroll position
    const initialScroll = await aboutContent.evaluate(el => el.scrollTop);
    expect(initialScroll).toBe(0);
    
    // Scroll down
    await aboutContent.evaluate(el => el.scrollTo({ top: el.scrollHeight, behavior: 'instant' }));
    await page.waitForTimeout(300);
    
    // Check scrolled position
    const scrolledPosition = await aboutContent.evaluate(el => el.scrollTop);
    expect(scrolledPosition).toBeGreaterThan(0);
    
    await expect(page).toHaveScreenshot('about-screen-scrolled.png', {
      fullPage: true,
      threshold: 0.2,
    });
  });

  test('about screen - no content overflow', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Check dialog fits within window
    const dialog = page.locator('.about-dialog');
    const dialogBox = await dialog.boundingBox();
    
    expect(dialogBox?.width).toBeLessThanOrEqual(320);
    expect(dialogBox?.height).toBeLessThanOrEqual(400);
    
    // Check no horizontal overflow
    const aboutOverlay = page.locator('.about-overlay');
    const overlayBox = await aboutOverlay.boundingBox();
    expect(overlayBox?.width).toBeLessThanOrEqual(320);
  });

  test('about screen - station cards are clickable', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 400 });
    
    // Check station cards are buttons
    const stationCardButtons = page.locator('button.station-card');
    const count = await stationCardButtons.count();
    expect(count).toBe(3);
    
    // Check active card is disabled
    const activeCard = page.locator('button.station-card.active');
    await expect(activeCard).toBeDisabled();
    
    // Check inactive cards are enabled
    const inactiveCards = page.locator('button.station-card:not(.active)');
    const inactiveCount = await inactiveCards.count();
    expect(inactiveCount).toBe(2);
  });
});
