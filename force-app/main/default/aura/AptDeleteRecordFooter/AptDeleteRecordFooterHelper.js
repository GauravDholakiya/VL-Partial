/**
 * @author Jozef 
 * @date 19.6.2019.
 * @description //TODO
 */

({
   showSpinner: function(cmp) {
        var numOfRuns = cmp.get('v.numOfRuns');
        numOfRuns = numOfRuns + 1;
        cmp.set('v.numOfRuns', numOfRuns);
    },

     hideSpinner : function(cmp){
         var numOfRuns = cmp.get('v.numOfRuns');
         if (numOfRuns > 0){
            numOfRuns = numOfRuns - 1;
            cmp.set('v.numOfRuns', numOfRuns);
         }
    },
});