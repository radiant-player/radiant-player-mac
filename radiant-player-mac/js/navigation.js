/*
 * js/navigation.js
 *
 * This script is part of the JavaScript interface used to interact with
 * the Google Play Music page, adding back and forward buttons to the page.
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

// This check ensures that, even though this script is run multiple times, our code is only attached once.
if (typeof window.GMNavigation === 'undefined') {
    window.GMNavigation = { };
        
    var logoContainer = document.querySelector('.menu-logo');
    var buttonsContainer = document.querySelector('#material-one-left');
    var openNavButton = document.querySelector('#left-nav-open-button');
    
    var buttonsEnabled = window.GoogleMusicApp.preferenceForKey("navigation.buttons.enabled");
    var keepLogo = window.GoogleMusicApp.preferenceForKey("navigation.buttons.keep-logo");
    var keepLinks = window.GoogleMusicApp.preferenceForKey("navigation.buttons.keep-links");
    
    if (buttonsEnabled)
    {
        if (!keepLogo)
        {
            // Hide the Google Play Music logo.
            logoContainer.style.visibility = 'hidden';
        }
        
        // Move the button in the navigation menu to the right.
        var menuButton = document.querySelector('#left-nav-close-button');
        menuButton.parentNode.appendChild(menuButton);
        
        // Create back and forward buttons.
        var backButton = document.createElement('sj-icon-button');
        backButton.className = 'gm-nav-button';
        backButton.setAttribute('icon', 'arrow-back');
        backButton.setAttribute('aria-label', 'Back');
        backButton.setAttribute('role', 'button');
        backButton.addEventListener('click', function() { window.history.back(); });
        
        var forwardButton = document.createElement('sj-icon-button');
        forwardButton.className = 'gm-nav-button';
        forwardButton.setAttribute('icon', 'arrow-forward');
        forwardButton.setAttribute('aria-label', 'Forward');
        forwardButton.setAttribute('role', 'button');
        forwardButton.addEventListener('click', function() { window.history.forward(); });
        
        // Add the back and forward buttons.
        openNavButton.parentNode.insertBefore(forwardButton, openNavButton.nextSibling);
        openNavButton.parentNode.insertBefore(backButton, openNavButton.nextSibling);
    }
    
    if (!keepLinks)
    {
        // Obtain the area on the top-right, containing the Google account information.
        var rightArea = document.querySelector('#material-one-right > div:first-child > div:first-child > div:first-child');
        rightArea.style.minWidth = 0;
        
        // Remove all of the children, except the last (the user button).
        while (rightArea.childNodes.length > 1)
            rightArea.removeChild(rightArea.firstChild);
    }
    
    // Allow room for the Mac OS X traffic lights buttons.
    var paddingElement = document.createElement('div');
    paddingElement.id = 'rp-padding-left';
    buttonsContainer.parentNode.insertBefore(paddingElement, buttonsContainer);
    
    // Adjust the drawer navigation scrolling mode to accomodate the traffic light buttons.
    document.querySelector('#drawer #nav-container').setAttribute('mode', '');
    
    window.GMNavigation.Callbacks = {
        onHistoryChange: function(canGoBack, canGoForward) {
//            if (!buttonsEnabled)
//                return;
//            
//            var back = document.querySelector('#gm-back');
//            var forward = document.querySelector('#gm-forward');
//            
//            if (canGoBack)
//                back.classList.remove('inactive');
//            else
//                back.classList.add('inactive');
//            
//            
//            if (canGoForward)
//                forward.classList.remove('inactive');
//            else
//                forward.classList.add('inactive');
        }
    };
}