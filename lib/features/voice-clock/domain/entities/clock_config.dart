enum ClockType { digital, analog }

class ClockConfig {
  final ClockType type;
  final bool is24HourFormat;

  const ClockConfig({
    this.type = ClockType.digital,
    this.is24HourFormat = true,
  });
}