import 'package:flutter/material.dart';
import '../data/models/swap_proposal_model.dart';
import '../data/repositories/proposal_repository.dart';

class ProposalProvider extends ChangeNotifier {
  final ProposalRepository _repo = ProposalRepository();

  List<SwapProposalModel> _incomingProposals = [];
  List<SwapProposalModel> _outgoingProposals = [];
  bool _isLoading = false;

  List<SwapProposalModel> get incomingProposals => _incomingProposals;
  List<SwapProposalModel> get outgoingProposals => _outgoingProposals;
  bool get isLoading => _isLoading;

  Future<void> fetchAllProposals() async {
    _isLoading = true;
    notifyListeners();
    try {
      _incomingProposals = await _repo.getIncomingProposals();
      _outgoingProposals = await _repo.getOutgoingProposals();
    } catch (e) {
      debugPrint('Error fetching proposals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendProposal({
    required ProposalType type,
    required String targetItemId,
    String? offeredItemId,
    required String ownerId,
    String? note,
  }) async {
    try {
      await _repo.submitProposal(
        proposalType: type,
        targetItemId: targetItemId,
        offeredItemId: offeredItemId,
        ownerId: ownerId,
        note: note,
      );
      await fetchAllProposals();
      return true;
    } catch (e) {
      debugPrint('Error sending proposal: $e');
      return false;
    }
  }

  Future<void> updateStatus(String proposalId, ProposalStatus newStatus) async {
    await _repo.updateProposalStatus(proposalId, newStatus);
    await fetchAllProposals();
  }
}
