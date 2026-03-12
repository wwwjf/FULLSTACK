import 'package:cron/cron.dart';

class CronUtil {
  static final cron = Cron();
  static schedule(String schedule, Function() task) {
    cron.schedule(Schedule.parse(schedule), task);
  }
}