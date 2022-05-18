@isTest
public class BaseTriggerHelper_Tests {
	@isTest
    public static void implementorTests() {
		ImplementedBaseTriggerHelper hlpr = new ImplementedBaseTriggerHelper();
        hlpr.execute(null);
        hlpr.execute(null, null);
        hlpr.getUnitsOfWork();
    }
    
    public class ImplementedBaseTriggerHelper 
        extends BaseTriggerHelper 
    {
    }
}