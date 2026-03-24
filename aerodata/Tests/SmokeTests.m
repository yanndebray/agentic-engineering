classdef SmokeTests < matlab.unittest.TestCase
    methods (TestClassSetup)
        function projectMustBeOpen(testCase)
            testCase.assumeNotEmpty(currentProject);
        end

        function closeNewFigures(testCase)
            existingFigures = findall(groot,"Type","Figure");
            testCase.addTeardown(@() delete(setdiff(findall(groot,"Type","Figure"),existingFigures)))
        end
    end

    methods (Test)
        function sampleDataFileExists(testCase)
            project = currentProject();
            projectRoot = string(project.RootFolder);
            testCase.verifyTrue(isfile(fullfile(projectRoot,"data","652200101092009.mat")));
        end

        function demoRunsWithoutWarnings(testCase)
            project = currentProject();
            projectRoot = string(project.RootFolder);
            demoFile = fullfile(projectRoot,"Demos","exploreFlightData.m");
            demoCommand = "run('" + replace(string(demoFile),"'","''") + "')";
            testCase.verifyWarningFree(@() evalin("base",demoCommand));
        end
    end
end
