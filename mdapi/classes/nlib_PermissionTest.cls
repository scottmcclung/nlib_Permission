@IsTest
private class nlib_PermissionTest
{
  /**
   * Since APEX is not able to generate a test specific custom permission
   * you'll need to create a custom permission to use in your tests and
   * change this value to the name of that test permission.
   */
  public static final String CUSTOM_PERMISSION = 'Test_Permission';
  
  
  
  
  @isTest
  static void itShouldReturnTrueForSingleUser()
  {
    createUserWithCustomPermission();
    System.assertEquals( true, nlib_Permission.userHasPermission( getUser().Id, CUSTOM_PERMISSION ) );
  }
  
  
  
  
  @isTest
  static void itShouldReturnFalseForSingleUser()
  {
    System.assertEquals( false, nlib_Permission.userHasPermission( getUser().Id, CUSTOM_PERMISSION ) );
  }
  
  
  
  
  @isTest
  static void itShouldReturnTrueWhenInvokedByFlow()
  {
    createUserWithCustomPermission();
    
    nlib_Permission.Assignment objAssignment = new nlib_Permission.Assignment();
    objAssignment.userId = getUser().Id;
    objAssignment.permissionName = CUSTOM_PERMISSION;
    
    nlib_Permission.Assignment[] lstAssignments = new nlib_Permission.Assignment[]{ objAssignment };
    nlib_Permission.AssignmentResponse[] lstResponses = nlib_Permission.usersHavePermission( lstAssignments );
    System.assertEquals( true, lstResponses[ 0 ].isAssigned );
  }
  
  
  
  
  @isTest
  static void itShouldReturnFalseWhenInvokedByFlow()
  {
    nlib_Permission.Assignment objAssignment = new nlib_Permission.Assignment();
    objAssignment.userId = getUser().Id;
    objAssignment.permissionName = CUSTOM_PERMISSION;
    
    nlib_Permission.Assignment[] lstAssignments = new nlib_Permission.Assignment[]{ objAssignment };
    nlib_Permission.AssignmentResponse[] lstResponses = nlib_Permission.usersHavePermission( lstAssignments );
    System.assertEquals( false, lstResponses[ 0 ].isAssigned );
  }
  
  
  
  
  static void createUserWithCustomPermission()
  {
    PermissionSet objPermissionSet = new PermissionSet(
      Name = 'ExamplePermissionSet',
      Label = 'Example Permission Set' );
    insert objPermissionSet;
    
    SetupEntityAccess objSetupEntityAccess = new SetupEntityAccess(
      ParentId = objPermissionSet.Id,
      SetupEntityId = getCustomPermission().Id );
    insert objSetupEntityAccess;
    
    PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment(
      AssigneeId = getUser().Id,
      PermissionSetId = objPermissionSet.Id );
    insert objPermissionSetAssignment;
  }
  
  
  
  
  static User getUser()
  {
    return [SELECT Id FROM User WHERE username = 'standarduser@testorg.example.com' LIMIT 1][ 0 ];
  }
  
  
  
  
  static CustomPermission getCustomPermission()
  {
    CustomPermission[] lstPermissions = [SELECT Id FROM CustomPermission WHERE DeveloperName = :CUSTOM_PERMISSION LIMIT 1];
    if(lstPermissions.size() == 0) {
      throw new PermissionTestException( 'The custom permission expected for testing was not found. Make sure to create a custom permission and change the CUSTOM_PERMISSION variable to reflect that permission.' );
    }
    return lstPermissions[ 0 ];
  }
  
  
  
  
  @TestSetup
  static void setup()
  {
    Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
    
    User objUser = new User(
      Alias = 'standt',
      Email = 'standarduser@testorg.example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Example Last Name',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = objProfile.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'standarduser@testorg.example.com' );
    insert objUser;
  }
  
  
  
  
  public class PermissionTestException extends Exception {}
}