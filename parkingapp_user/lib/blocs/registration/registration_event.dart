part of 'registration_bloc.dart';

abstract class RegistrationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RegistrationSubmitted extends RegistrationEvent {
  final String name;
  final String personNum;
  final String confirmPersonNum;

  RegistrationSubmitted({
    required this.name,
    required this.personNum,
    required this.confirmPersonNum,
  });

  @override
  List<Object> get props => [name, personNum, confirmPersonNum];
}
