if (typeof window.Styles === 'undefined') {
    window.Styles = {
        appliedStyles: {},
        
        applyStyle: function(key, css) {
            if (Styles.appliedStyles[key]) {
                Styles.appliedStyles[key].disabled = false;
            }
            else {
                var style = document.createElement('style');
                style.type = 'text/css';
                style.innerHTML = css;
                style.id = 'style-' + key;
                
                document.getElementsByTagName('head')[0].appendChild(style);
                Styles.appliedStyles[key] = style;
            }
        },
        
        disableStyle: function(key) {
            if (Styles.appliedStyles[key]) {
                Styles.appliedStyles[key].disabled = true;
            }
        }
    };
}