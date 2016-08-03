/*
* js/lucky.js
*
* This script is part of the JavaScript interface used to interact with
* the Google Play Music page, adding I'm feeling lucky to the page / mini player.
*
* Created by Baraka Aka 1Only.
*
* Subject to terms and conditions in LICENSE.md.
*
*/

if(typeof Radiant == "undefined") {
    var Radiant = {};
}

Radiant = {
    load: function() {
        Radiant.Lucky();
    },
    Lucky: function() {
        var lucky = Radiant.create('<div class="material-card material-shadow-z1" data-size="small" data-type="imfl" data-id="" data-log-position="0"><div class="image-wrapper"><div class="image-inner-wrapper"><img class="image" src="https://play-music.gstatic.com/fe/75c74ef2930c12f49710ccf42c5fb3bb/ifl_card_art.png" alt="" draggable="false"></div></div><div class="details"><div class="details-inner"><a class="title tooltip fade-out" href="">I\'m feeling lucky radio</a><div class="sub-title tooltip fade-out">Based on your music taste</div></div></div></div>');

        var readyStateChecker = setInterval(function() {
            if(document.readyState == "complete"){
                document.body.insertBefore(lucky, document.body.childNodes[0]);
                clearInterval(readyStateChecker);
            }
        }, 10);
    },
    create: function(Baraka) {
        var radiant = document.createDocumentFragment(),
        temp = document.createElement('div');
        temp.innerHTML = Baraka;
        while (temp.firstChild) {
            radiant.appendChild(temp.firstChild);
        }
    return radiant;
    }
}

Radiant.load();