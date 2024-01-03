/**
 * Created by jozef on 18. 5. 2023.
 * Description: Process is scheduled for a specific day
 */

global class AptActionPlanCreationSchedule implements Schedulable {
    global void execute(SchedulableContext param1) {
        Id createPlanBatch = Database.executeBatch(new AptActionPlanCreationBatch(),3);
    }

}