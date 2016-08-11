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
        var lucky = Radiant.create('<div class="material-card" data-type="imfl" style="display:none"></div>');

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