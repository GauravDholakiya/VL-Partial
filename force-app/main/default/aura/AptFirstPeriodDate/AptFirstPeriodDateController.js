/**
 * Created by jozef on 4. 4. 2023.
 */

({
    init : function(cmp, event, helper){
        helper.setFirstPeriodDate(cmp);
    },

    editPeriodsSavePressed : function(cmp, event, helper){
        helper.setFirstPeriodDate(cmp);
    },

    firstPeriodDateChanged: function(cmp, event, helper){
        helper.sendFirstPeriodDateChangedEvt(cmp);
    },

    recalculateFirstPeriod: function(cmp, event, helper){
        helper.setFirstPeriodDate(cmp);
    },
});