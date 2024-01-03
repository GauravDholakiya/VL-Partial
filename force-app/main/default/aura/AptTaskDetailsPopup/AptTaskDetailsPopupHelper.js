/**
 * Created by jozef on 6. 4. 2023.
 */

({

    setPosition: function(cmp){
        //console.log('setPositionIn');
        let text = cmp.find('textId');
        let toolTipCss = cmp.get('v.boxClass');
        let heightOfPopover = 0;
        if (text && $A.util.isEmpty(toolTipCss)){
            //console.log('setPositionDo');
            let element = text.getElement();
            heightOfPopover = element.offsetHeight;
            //console.log('element.offsetHeight inside ' + element.offsetHeight);
            $A.util.toggleClass(text, "toggle");
            this.setToolTipCss(cmp, heightOfPopover);
            $A.util.removeClass(text, "toggle");
        }
    },


    setToolTipCss: function(cmp, height){
        let periodNumber = cmp.get('v.periodNumber');
        let toolTipCss = '';
        let toolTipElement;
        let docElement;
        let top;
        let left;
        let leftConst = 210;
        let topPosition = height;
        if (periodNumber == '1'){
            leftConst = 160;
        }else if (periodNumber == '12'){
            leftConst = 250;
        }
        let periodLinkTop = cmp.get('v.periodLinkTop');
        let periodLinkLeft = cmp.get('v.periodLinkLeft');
        top = periodLinkTop - topPosition;
        left = periodLinkLeft - leftConst;
        toolTipCss = "position: absolute; top:"+ top + "px; left:" + left + "px";
        cmp.set('v.boxClass', toolTipCss);
    },

});