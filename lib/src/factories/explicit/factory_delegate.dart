import 'package:activatory/src/activation_context.dart';

/// Activation call delegate.
typedef FactoryDelegate<T> = T Function(ActivationContext activatory);
