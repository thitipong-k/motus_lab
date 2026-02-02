import os
import json
import time
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# 1. Setup Firebase Admin
# หาสถานที่ตั้งของสคริปต์เพื่อให้เข้าถึงไฟล์ service-account.json ได้เสมอไม่ว่าจะรันจากที่ไหน
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_PATH = os.path.join(SCRIPT_DIR, 'service-account.json')

if not os.path.exists(SERVICE_ACCOUNT_PATH):
    print(f"Error: Missing {SERVICE_ACCOUNT_PATH}. Please download it from Firebase Console.")
    exit(1)

cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)
db = firestore.client()

def seed_file(asset_path, default_brand):
    if not os.path.exists(asset_path):
        print(f"Skipping: {asset_path} (Not found)")
        return

    print(f"\n--- Processing: {asset_path} (Default Brand: {default_brand}) ---")
    
    with open(asset_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    batch_size = 450 # Firestore limit is 500
    total = len(data)
    
    for i in range(0, total, batch_size):
        batch = db.batch()
        chunk = data[i:i + batch_size]
        
        for item in chunk:
            code = item.get('Code') or item.get('code') or 'UNKNOWN'
            description = item.get('Description') or item.get('description') or item.get('title') or ''
            
            # Smart Brand Detection
            brand = str(item.get('manufacturer', default_brand)).lower().strip()
            
            # Sanitization: ป้องกันเครื่องหมาย / ใน code หรือ brand เพราะจะทำให้ Firestore คิดว่าเป็น Path ย่อย
            # และทำให้อะเลอเร่อ "even number of path elements"
            code = code.replace('/', '_').replace('\\', '_')
            brand = brand.replace('/', '_').replace('\\', '_')

            if not code or not brand:
                continue

            doc_ref = db.collection('knowledge_base').document('dtcs').collection(brand).document(code)
            
            payload = {
                'code': code,
                'description': description,
                'brand': brand,
                'lastUpdated': firestore.SERVER_TIMESTAMP,
                'isVerified': False,
                'seededBy': 'system_admin'
            }
            
            # Rich Data Support
            if 'causes' in item: payload['causes'] = item['causes']
            if 'type' in item: payload['type'] = item['type']
            if 'is_generic' in item: payload['is_generic'] = item['is_generic']
            
            batch.set(doc_ref, payload, merge=True)
        
        while True:
            try:
                batch.commit()
                print(f"Progress: {min(i + batch_size, total)} / {total}")
                break # Success, exit retry loop
            except Exception as e:
                if "Quota exceeded" in str(e) or "429" in str(e):
                    print(f"⚠️ Quota Exceeded. Waiting 10 seconds before retry...")
                    time.sleep(10)
                    continue
                else:
                    print(f"❌ Critical Error: {e}")
                    raise e
        
        # เพิ่มจุดพักเล็กน้อยในสถานะปกติ
        time.sleep(0.5)

# รันการนำเข้าไฟล์ทั้งหมด
# ปรับให้หาโฟลเดอร์ assets อัตโนมัติโดยอ้างอิงจากตำแหน่งของสคริปต์
ASSETS_DIR = os.path.join(SCRIPT_DIR, '..', 'assets', 'data')

files_to_seed = [
    {'path': f'{ASSETS_DIR}/codes.json', 'brand': 'standard'},
    {'path': f'{ASSETS_DIR}/generic_codes.json', 'brand': 'standard'},
    {'path': f'{ASSETS_DIR}/diagnostic_data_th.json', 'brand': 'thailand'},
    {'path': f'{ASSETS_DIR}/dtc_definitions.json', 'brand': 'auto_detect'},
    {'path': f'{ASSETS_DIR}/obd-trouble-codes.json', 'brand': 'standard'},
]

for entry in files_to_seed:
    seed_file(entry['path'], entry['brand'])

print("\n🎉 Seeding Completed Successfully!")
