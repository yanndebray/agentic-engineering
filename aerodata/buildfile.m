function plan = buildfile
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask
plan = buildplan(localfunctions);
plan.DefaultTasks = "test";
plan("check") = CodeIssuesTask;
plan("test") = TestTask("Tests",Dependencies="check",TestResults="Results/test-results.html");
end
