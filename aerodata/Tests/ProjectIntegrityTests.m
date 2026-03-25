classdef ProjectIntegrityTests < matlab.unittest.TestCase
    methods (Test)
        function projectHasExpectedName(testCase)
            project = currentProject();
            testCase.assertNotEmpty(project);
            testCase.verifyEqual(string(project.Name),"aerodata-broken");
        end

        function expectedProjectFilesExist(testCase)
            project = currentProject();
            projectRoot = string(project.RootFolder);
            testCase.verifyTrue(isfolder(fullfile(projectRoot,"Demos")));
            testCase.verifyTrue(isfolder(fullfile(projectRoot,"Tests")));
            testCase.verifyTrue(isfolder(fullfile(projectRoot,"data")));
            testCase.verifyTrue(isfile(fullfile(projectRoot,"Demos","exploreFlightData.m")));
            testCase.verifyTrue(isfile(fullfile(projectRoot,"data","652200101092009.mat")));
        end
    end
end
