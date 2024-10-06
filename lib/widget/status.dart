import 'package:flutter/material.dart';

class DeliveryStatusTracker extends StatelessWidget {
  final int currentStep;

  const DeliveryStatusTracker({Key? key, required this.currentStep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStepCircle(0, Icons.document_scanner),
                  _buildConnector(0),
                  _buildStepCircle(1, Icons.assignment_turned_in),
                  _buildConnector(1),
                  _buildStepCircle(2, Icons.delivery_dining),
                  _buildConnector(2),
                  _buildStepCircle(3, Icons.check_circle_outline),
                ],
              ),
              const SizedBox(height: 8), // เพิ่มช่องว่างระหว่างวงกลมกับ label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('รอ Rider\nรับงาน', 0),
                    _buildLabel('ไรเดอร์รับงาน\nแล้วกำลังมา', 1),
                    _buildLabel('กำลังจัดส่ง', 2),
                    _buildLabel('ส่งแล้ว', 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCircle(int step, IconData icon) {
    final isActive = step <= currentStep;
    final color = isActive ? Color(0xFF412160) : Colors.grey.shade300;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildLabel(String label, int step) {
    final isActive = step <= currentStep;
    return Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isActive ? const Color(0xFF202442) : Colors.grey,
        fontSize: 12,
      ),
    );
  }

  Widget _buildConnector(int step) {
    return Expanded(
      child: Container(
        height: 2, // ความสูงของเส้น
        color: step < currentStep ? Color(0xFF412160) : Colors.grey.shade300,
      ),
    );
  }
}
