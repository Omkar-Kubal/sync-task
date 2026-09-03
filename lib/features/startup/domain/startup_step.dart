enum StartupStep {
  tasks,
  focus,
  done;

  String get routePath {
    return switch (this) {
      StartupStep.tasks => '/startup/tasks',
      StartupStep.focus => '/startup/focus',
      StartupStep.done => '/startup/done',
    };
  }

  StartupStep? get next {
    return switch (this) {
      StartupStep.tasks => StartupStep.focus,
      StartupStep.focus => StartupStep.done,
      StartupStep.done => null,
    };
  }
}
