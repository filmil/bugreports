// Navigates to the settings pages of a Chrome browser and tries to put a text
// into the search field on the settings page.
package main

import (
	"context"
	"log"
	"strings"
	"time"

	cdp "github.com/chromedp/chromedp"
)

func main() {
	allocCtx, cancel := cdp.NewExecAllocator(context.Background(), opts...)
	defer cancel()
	ctx, cancel := cdp.NewContext(
		allocCtx,
		cdp.WithLogf(log.Printf),
	)
	defer cancel()
	ctx, cancel = context.WithTimeout(ctx, 60*time.Second)
	defer cancel()
	if err := cdp.Run(ctx,
		cdp.Navigate(`chrome://settings/content/location`),
		cdp.SendKeys(`input`, "hello", cdp.ByID),
	); err != nil && !strings.Contains(err.Error(), "net::ERR_ABORTED") {
		log.Fatal(err)
	}
	pause := make(chan struct{})
	<-pause
}

var (
	// opts is the same as default options, except no headless browser.
	opts []cdp.ExecAllocatorOption = []cdp.ExecAllocatorOption{
		cdp.NoFirstRun,
		cdp.NoDefaultBrowserCheck,
		cdp.Flag("browser-startup-dialog", false),
		cdp.Flag("disable-geolocation", true),
		cdp.Flag("disable-background-networking", true),
		cdp.Flag("disable-background-timer-throttling", true),
		cdp.Flag("disable-backgrounding-occluded-windows", true),
		cdp.Flag("disable-breakpad", true),
		cdp.Flag("disable-client-side-phishing-detection", true),
		cdp.Flag("disable-default-apps", true),
		cdp.Flag("disable-dev-shm-usage", true),
		cdp.Flag("disable-extensions", true),
		cdp.Flag("disable-features", "site-per-process,Translate,BlinkGenPropertyTrees"),
		cdp.Flag("disable-hang-monitor", true),
		cdp.Flag("disable-ipc-flooding-protection", true),
		cdp.Flag("disable-notifications", true),
		cdp.Flag("disable-popup-blocking", true),
		cdp.Flag("disable-prompt-on-repost", true),
		cdp.Flag("disable-renderer-backgrounding", true),
		cdp.Flag("disable-sync", true),
		cdp.Flag("enable-automation", true),
		cdp.Flag("enable-features", "NetworkService,NetworkServiceInProcess"),
		cdp.Flag("force-color-profile", "srgb"),
		cdp.Flag("metrics-recording-only", true),
		cdp.Flag("password-store", "basic"),
		cdp.Flag("safebrowsing-disable-auto-update", true),
		cdp.Flag("use-mock-keychain", true),
		cdp.Flag("enable-logging", true),
	}
)
