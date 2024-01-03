/**
 * Created by jozef on 6. 4. 2023.
 */

({
    doInit: function(cmp, event, helper) {

    },

    onRender: function(cmp, event, helper) {
        helper.setPosition(cmp);
    },

    closeModal: function(cmp, event, helper) {
        cmp.set('v.panelDisplay', false);
    },
});