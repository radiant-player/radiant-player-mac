/*
 * js/main.js
 *
 * This script is part of the JavaScript interface used to interact with
 * the Google Play Music page, in order to provide notifications functionality.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

if (typeof window.gmusic === 'undefined') {
  var gmusic = window.gmusic = new window.GMusic(window);

  // Hook into parent app

  var DEBUG = false;
  var VERBOSE = false;

  gmusic.on('change:song', function(song) {
    if (DEBUG) console.info('change:song', arguments);
    GoogleMusicApp.notifySong(
      song.title, song.artist, song.album, song.art, song.duration
    );
    
    if (document.querySelector("#BarakaMaterial") !== null) {
        document.getElementById("BarakaMaterial").remove();
    }
            
    if (document.querySelector("#BarakaMaterial-box") !== null) {
        document.getElementById("BarakaMaterial-box").remove();
    }
            
    if (document.querySelector(".BarakaModal") !== null) {
        document.querySelector(".BarakaModal").remove();
    }
            
    if (document.querySelector("#baraka-modal") !== null) {
        document.getElementById("baraka-modal").remove();
    }
            
    BarakaRadiant.init();
  });

  gmusic.on('change:shuffle', function(mode) {
    if (DEBUG) console.info('change:shuffle', arguments);
    GoogleMusicApp.shuffleChanged(mode);
  });

  gmusic.on('change:repeat', function(mode) {
    if (DEBUG) console.info('change:repeat', arguments);
    GoogleMusicApp.repeatChanged(mode);
  });

  gmusic.on('change:playback', function(mode) {
    if (DEBUG) console.info('change:playback', arguments);
    GoogleMusicApp.playbackChanged(mode);
    
    var baraka;
            
    if(mode === 0) {
        if (document.querySelector("#BarakaMaterial") !== null) {
            document.getElementById("BarakaMaterial").remove();
        }
            
        if (document.querySelector("#BarakaMaterial-box") !== null) {
            document.getElementById("BarakaMaterial-box").remove();
        }
            
        if (document.querySelector(".BarakaModal") !== null) {
            document.querySelector(".BarakaModal").remove();
        }
            
        if (document.querySelector("#baraka-modal") !== null) {
            document.getElementById("baraka-modal").remove();
        }
            
        BarakaRadiant.removeByClass("BarakaModal_bg");
            
        baraka = "remove BarakaLyrics";
        /* Initialize it again so there is no conflicts */
        BarakaRadiant.init();
        if (document.querySelector("#BarakaMaterial") !== null) {
            document.getElementById('BarakaMaterial').style.display = "none";
        }
    } else if(mode === 1) {
            
        var elements = document.getElementsByClassName("BarakaModal");
        for(var i=0; i<elements.length; i++) {
            var active = BarakaRadiant.hasClass(document.querySelector("#"+elements[i].id), 'BarakaModal-active');
            if(active) {
                document.querySelector("#"+elements[i].id).classList.toggle('BarakaHide');
            }
        }
            
        if (document.querySelector("#BarakaMaterial") !== null) {
            document.getElementById('BarakaMaterial').style.display = "none";
        }
            
        if(BarakaRadiant.hasClass(document.querySelector(".BarakaMaterial-box"), 'BarakaMaterial-box--show')) {
            if (document.querySelector('.BarakaMaterial-box--show') !== null) {
                if (document.querySelector('.BarakaMaterial-box--show').style.opacity !== "0") {
                    ocument.querySelector('.BarakaMaterial-box--show').style.opacity = "0";
                } else {
                    document.querySelector('.BarakaMaterial-box--show').style.opacity = "1";
                }
            }
        }
            
            baraka = "Hide BarakaLyrics";
    } else if(mode === 2) {
            
        var elements = document.getElementsByClassName("BarakaModal");
        for(var i=0; i<elements.length; i++) {
            var active = BarakaRadiant.hasClass(document.querySelector("#"+elements[i].id), 'BarakaModal-active');
            if(active) {
                document.querySelector("#"+elements[i].id).classList.toggle('BarakaHide');
            }
        }
            
        if(BarakaRadiant.hasClass(document.querySelector(".BarakaMaterial-box"), 'BarakaMaterial-box--show')) {
            if (document.querySelector('.BarakaMaterial-box--show') !== null) {
                if (document.querySelector('.BarakaMaterial-box--show').style.opacity == "0") {
                    document.querySelector('.BarakaMaterial-box--show').style.opacity = "1";
                } else {
                    document.querySelector('.BarakaMaterial-box--show').style.opacity = "1";
                }
            }
        }
            
        if (document.querySelector("#BarakaMaterial") !== null) {
            document.getElementById('BarakaMaterial').style.display = "block";
        }
        
        baraka = "Show BarakaLyrics";
    } else {
        // do nothing - baraka
    }
    
    if (DEBUG)  console.info('change:playback', baraka+': '+mode);
            
  });

  gmusic.on('change:playback-time', function(info) {
    if (DEBUG && VERBOSE) console.info('change:playback-time', arguments);
    GoogleMusicApp.playbackTimeChanged(info.current, info.total);
  });

  gmusic.on('change:rating', function (rating) {
    if (DEBUG) console.info('change:rating', arguments);
    GoogleMusicApp.ratingChanged(rating);
  });
}
