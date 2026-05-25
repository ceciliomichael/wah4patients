import { InteroperabilityProviderSummary } from './integration.types';

export type AppointmentBookingMode = 'onsite' | 'teleconsultation';

export interface AppointmentPushRequestPayload {
  targetProviderId: string;
  appointmentMode: AppointmentBookingMode;
  appointmentType: string;
  scheduledAt: string;
  durationMinutes: number;
  locationOrPlatform: string;
  identifierSystem: string;
  identifierValue: string;
  reason?: string;
  notes?: string;
}

export interface FhirAppointmentParticipantIdentifier {
  system: string;
  value: string;
}

export interface FhirAppointmentParticipantActor {
  type: 'Patient' | 'Practitioner';
  identifier: FhirAppointmentParticipantIdentifier;
}

export interface FhirAppointmentParticipant {
  actor: FhirAppointmentParticipantActor;
  status: 'accepted' | 'needs-action';
  required?: 'required' | 'optional' | 'information-only';
}

export interface FhirAppointmentNote {
  text: string;
}

export interface FhirAppointmentReasonCode {
  text: string;
}

export interface FhirAppointmentResource {
  resourceType: 'Appointment';
  meta?: { profile: string[] };
  identifier?: Array<{ use?: string; system: string; value: string }>;
  status: 'proposed';
  serviceCategory?: Array<{ coding: Array<{ system: string; code: string; display?: string }> }>;
  description: string;
  start: string;
  end: string;
  participant: FhirAppointmentParticipant[];
  reasonCode: FhirAppointmentReasonCode[];
  note: FhirAppointmentNote[];
}

export interface AppointmentPushGatewayRequest {
  senderId: string;
  targetId: string;
  correlationId: string;
  resource: FhirAppointmentResource;
  data?: FhirAppointmentResource;
  reason?: string;
  notes?: string;
}

export interface AppointmentPushResponse {
  message: string;
  transactionId: string;
  correlationId: string;
  requesterId: string;
  targetProvider: InteroperabilityProviderSummary;
  appointment: FhirAppointmentResource;
  gatewayUrl: string;
}
