import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/swap_proposal_model.dart';

class ProposalRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<SwapProposalModel>> getIncomingProposals() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final data = await _client.from('swap_proposals').select('''
      *,
      target_item:target_item_id (*),
      offered_item:offered_item_id (*),
      proposer:proposer_id (id, full_name, avatar_url, city, items_saved_count, created_at)
    ''').eq('owner_id', user.id).order('created_at', ascending: false);

    return (data as List).map((json) => SwapProposalModel.fromJson(json)).toList();
  }

  Future<List<SwapProposalModel>> getOutgoingProposals() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final data = await _client.from('swap_proposals').select('''
      *,
      target_item:target_item_id (*),
      offered_item:offered_item_id (*),
      proposer:proposer_id (id, full_name, avatar_url, city, items_saved_count, created_at)
    ''').eq('proposer_id', user.id).order('created_at', ascending: false);

    return (data as List).map((json) => SwapProposalModel.fromJson(json)).toList();
  }

  Future<void> submitProposal({
    required ProposalType proposalType,
    required String targetItemId,
    String? offeredItemId,
    required String ownerId,
    String? note,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Silakan login terlebih dahulu.');

    await _client.from('swap_proposals').insert({
      'proposal_type': proposalType.name,
      'target_item_id': targetItemId,
      'offered_item_id': offeredItemId,
      'proposer_id': user.id,
      'owner_id': ownerId,
      'note': note,
      'status': 'pending',
    });
  }

  Future<void> updateProposalStatus(String proposalId, ProposalStatus newStatus) async {
    await _client.from('swap_proposals').update({
      'status': newStatus.name,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', proposalId);
  }
}
