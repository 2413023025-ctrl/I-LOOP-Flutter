import 'item_model.dart';
import 'profile_model.dart';

enum ProposalType { swap, share }
enum ProposalStatus { pending, accepted, rejected, completed, cancelled }

class SwapProposalModel {
  final String id;
  final ProposalType proposalType;
  final String targetItemId;
  final String? offeredItemId;
  final String proposerId;
  final String ownerId;
  final String? note;
  final ProposalStatus status;
  final DateTime createdAt;
  final ItemModel? targetItem;
  final ItemModel? offeredItem;
  final ProfileModel? proposer;

  SwapProposalModel({
    required this.id,
    required this.proposalType,
    required this.targetItemId,
    this.offeredItemId,
    required this.proposerId,
    required this.ownerId,
    this.note,
    this.status = ProposalStatus.pending,
    required this.createdAt,
    this.targetItem,
    this.offeredItem,
    this.proposer,
  });

  factory SwapProposalModel.fromJson(Map<String, dynamic> json) {
    ProposalType type = json['proposal_type'] == 'share' ? ProposalType.share : ProposalType.swap;

    ProposalStatus st = ProposalStatus.pending;
    final stStr = json['status'] as String?;
    if (stStr == 'accepted') st = ProposalStatus.accepted;
    if (stStr == 'rejected') st = ProposalStatus.rejected;
    if (stStr == 'completed') st = ProposalStatus.completed;
    if (stStr == 'cancelled') st = ProposalStatus.cancelled;

    ItemModel? target;
    if (json['target_item'] != null) {
      target = ItemModel.fromJson(json['target_item'] as Map<String, dynamic>);
    }

    ItemModel? offered;
    if (json['offered_item'] != null) {
      offered = ItemModel.fromJson(json['offered_item'] as Map<String, dynamic>);
    }

    ProfileModel? user;
    if (json['proposer'] != null) {
      user = ProfileModel.fromJson(json['proposer'] as Map<String, dynamic>);
    }

    return SwapProposalModel(
      id: json['id'] as String,
      proposalType: type,
      targetItemId: json['target_item_id'] as String,
      offeredItemId: json['offered_item_id'] as String?,
      proposerId: json['proposer_id'] as String,
      ownerId: json['owner_id'] as String,
      note: json['note'] as String?,
      status: st,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      targetItem: target,
      offeredItem: offered,
      proposer: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proposal_type': proposalType.name,
      'target_item_id': targetItemId,
      'offered_item_id': offeredItemId,
      'proposer_id': proposerId,
      'owner_id': ownerId,
      'note': note,
      'status': status.name,
    };
  }
}
