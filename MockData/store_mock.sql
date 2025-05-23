
INSERT INTO store (
    store_id,
    store_name,
    store_location,
	code,
	image_url
) 
VALUES
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'SuperMart Downtown', '123 Main Street, Downtown', 'STOR000001', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'QuickShop Central', '456 Center Avenue, Central', 'STOR000002', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'MegaStore North', '789 North Road, Uptown', 'STOR000003', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444', 'BudgetMart East', '321 East Lane, Eastside', 'STOR000004', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('e5b3c2f1-2d75-4f3a-9a21-3b4a1c8f5555', 'ValueShop West', '654 West Street, Westend', 'STOR000005', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('f6c4e1a7-1b63-41c2-bf82-2f1c7a5b6666', 'Neighborhood Market', '987 South Avenue, Southside', 'STOR000006', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('a7d2b5c3-6f14-49c2-9f31-7a1c4b2f7777', 'FreshMart Hills', '159 Hills Road, Hilltop', 'STOR000007', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('b8e1c3f7-4a62-48d2-bf41-1c7a2b8f8888', 'GreenLeaf Organic', '753 Garden Street, Greenfield', 'STOR000008', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('c9f7a2d1-3b81-4e2a-bf24-4a1c5b7f9999', 'Urban Market', '246 City Center Blvd, Midtown', 'STOR000009', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('d0a5e4c8-2b17-4f3a-bc52-3f1a7c2f0000', 'Family Grocery', '369 Maple Avenue, Riverside', 'STOR000010', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('f47ac10b-58cc-4372-a567-0e02b2c3d479', 'Downtown Market', '123 Main Street, Downtown', 'STOR000011', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('9c858901-8a57-4791-81fe-4c455b099bc9', 'Uptown Grocery', '456 Elm Street, Uptown', 'STOR000012', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('3fa85f64-5717-4562-b3fc-2c963f66afa6', 'Central Plaza Store', '789 Oak Avenue, Central Plaza', 'STOR000013', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('16fd2706-8baf-433b-82eb-8c7fada847da', 'Riverside Mart', '321 River Road, Riverside', 'STOR000014', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('7c9e6679-7425-40de-944b-e07fc1f90ae7', 'Hilltop Supplies', '654 Pine Street, Hilltop', 'STOR000015', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png');

INSERT INTO pos_device (device_id,store_id,hashed_token,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0b75b5e2-444f-4b0d-8742-ccdb20ae2e0e'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEIVwvAMb4g3A11p5V5UYWqlsZh53mCqqUvx3Bg/zVrkQjaJnCTYVZplZ/7t46DgOMQ==','2025-05-08 10:12:24.948182','STORE1_DEV4','2025-04-08 10:09:51.619462','2025-04-08 10:12:05.611998',false,false),
	 ('3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEGEux9TAcCmeyB8Sq/TC/41kda4KrvKnJ3lVsnAhtP4NZJK1hSc0Mewx1hnUhXZtmA==','2025-05-08 10:28:51.850073','TEST_DEV_1','2025-04-04 11:59:46.41674','2025-04-08 10:28:51.850082',false,false),
	 ('543be31d-eb6e-43fa-be7c-f8b3dcde0f70'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEPOQfuw0KDXV/IUB7qGLXaQq3W0K7m9fk4B0D+hgcBOcrij1Ago7HoekGUrBsZz4aA==','2025-05-08 10:27:45.385024','STORE1_DEV1','2025-04-08 09:56:11.436709','2025-04-08 10:27:45.385189',false,false),
	 ('625f0c18-2248-4991-82ff-f7add17302d9'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEOOsqIZxmarEQfDV8jc6oD7Y1VMPXktJXHtmsufXnT7E2kwFuV+j5SEv+AuxGP3bbA==','2025-05-08 08:48:43.573576','TRUNG1','2025-04-08 08:37:06.335411','2025-04-08 08:48:43.573974',false,false),
	 ('e5de17a0-4754-4195-b14e-dfd3653a6139'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEEi9Gjzfv2fqR0lxnSWplsoiDXNLMPlzEVCX8cEpErjjO6W878N9peb5a3zvYz47Kg==','2025-05-08 10:32:42.363662','STORE1_DEV3','2025-04-08 10:08:43.527947','2025-04-08 10:32:42.363666',false,false),
	 ('3fa85f64-5717-4562-b3fc-2c963f66a002'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEOUSp+LCpmkU+M7jx41Zd2Z0IxANdL7rDgrD5GuEnrmR/gNN7IJe2UfLg/oKLMKNSw==','2025-05-08 10:32:52.573886','TEST_DEV_2','2025-04-04 11:59:46.41674','2025-04-08 10:32:52.5739',true,false),
	 ('4f03b994-3900-41ed-859a-2b913ade4dcb'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEIx7PQvTZ7QISAio7ms1Qz/FwIQIi326MqSkH/GwoFbzAEbbVgPbK5UiVFHQE6FwPQ==','2025-05-08 09:34:35.269049','TRUNG2','2025-04-08 09:22:06.630657','2025-04-08 09:34:35.269065',false,false),
	 ('3fa85f64-5717-4562-b3fc-2c963f66a003'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEPbVD/Idxlc/vu1z8doMpicImrJmH86k19FQiRDTwSNtcJaXs+f1BnCwTMaH+QjkzQ==','2025-05-08 10:32:55.725334','TEST_DEV_3','2025-04-04 11:59:46.41674','2025-04-08 10:32:55.725339',true,false),
	 ('b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'AQAAAAIAAYagAAAAEMIl/sG/7QChYsOkTm6wa4PnHz2qPr6cCBDVOZ3yHm5ZzdGvUb2ZEV7c7c5hIL5AkA==','2025-05-08 10:08:33.284367','STORE1_DEV2','2025-04-08 09:59:13.334279','2025-04-08 10:08:33.289',false,false),
	 ('d24f315e-c78b-4de7-8920-c0a50a4e5954'::uuid,'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222'::uuid,'AQAAAAIAAYagAAAAEHaQIotmTRfaeOACmOIeaJDXr4VLzqvon9l2+F+Lw52EWHjzK6m31ZbUjoN0HWhXmg==','2025-05-08 10:30:08.211875','STORE2_DEV1','2025-04-08 10:18:50.066566','2025-04-08 10:30:08.211884',false,false);
INSERT INTO pos_device (device_id,store_id,hashed_token,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0eba4315-de43-477e-bf4d-b29cdc49f4f7'::uuid,'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222'::uuid,'AQAAAAIAAYagAAAAEAl7Bqlrd/9u4alRRRvVVBkIKTAblodLAzizdS+BzJuNfTx3RNhn/x7r+uFXv90Czg==','2025-05-08 10:20:22.512675','STORE2_DEV2','2025-04-08 10:20:22.372017','2025-04-08 10:20:22.512698',false,false),
	 ('b57bae4f-d377-4334-a353-84c7b8deaff8'::uuid,'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222'::uuid,'AQAAAAIAAYagAAAAEDHXH0IMdK0+js3CHPqeOQvqz3YUzj4IknB1wElr0ZaigvVhxYVz/bPj/xMzy4oQzA==','2025-05-08 10:20:49.316239','STORE2_DEV3','2025-04-08 10:20:49.192387','2025-04-08 10:20:49.316244',false,false),
	 ('ee830759-a26a-4bb9-9a61-6f1775636201'::uuid,'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333'::uuid,'AQAAAAIAAYagAAAAELZtlNRUDPbvXrSc+zfVi8gUIEtikQPwf8RVD7KGsyK6wtnOb2XhBJrl52tzQztYMA==','2025-05-08 10:31:27.333286','STORE3_DEV3','2025-04-08 10:31:27.17926','2025-04-08 10:31:27.333292',false,false),
	 ('973711f4-2d2d-4acb-99cb-1b1303d0a147'::uuid,'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333'::uuid,'AQAAAAIAAYagAAAAEEfJzUOV9ZfXyCpgvAHXikuBN9ZAegAl5dn3RjnZu/WGZPSV1ppbwXlDzWLShUdKAQ==','2025-05-08 10:31:23.133058','STORE3_DEV2','2025-04-08 10:31:22.977947','2025-04-08 10:31:23.133065',false,false),
	 ('f5d3a5d1-d46d-4bdc-bdbe-dafd3d81d268'::uuid,'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333'::uuid,'AQAAAAIAAYagAAAAEMWyGsAiS+pH8CKJ6iojJE9XXyuUYJWLzIurXVel3v8kZgLkZrGVbVsmcJEzFkLR/A==','2025-05-08 10:31:19.824117','STORE3_DEV1','2025-04-08 10:31:19.605487','2025-04-08 10:31:19.824124',false,false),
	 ('9b9ffbf7-31c3-49b0-ae87-2bd510eb32ba'::uuid,'d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444'::uuid,'AQAAAAIAAYagAAAAEPc2nynJu+ygsJSi0pZnvzYpYe+HzCI9eRzkkMquHjbxXFcw92tISq8rR7ll31IgHg==','2025-05-08 10:32:05.439149','STORE4_DEV1','2025-04-08 10:32:05.27797','2025-04-08 10:32:05.439164',false,false),
	 ('31c91189-25ab-4a20-ac14-d3b2bce4f0ce'::uuid,'d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444'::uuid,'AQAAAAIAAYagAAAAEDxY9B98Cyswl3W5fxfDChqxJ2xRs9Rmwjn1/7zwqEs9p/I3Cmo7N8Oz8U3NdViE7A==','2025-05-08 10:32:12.649746','STORE4_DEV3','2025-04-08 10:32:12.493116','2025-04-08 10:32:12.649762',false,false),
	 ('1366abf3-5a60-4c87-ab2e-2d16a6d60fc4'::uuid,'d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444'::uuid,'AQAAAAIAAYagAAAAEAy5cscliZkR5HRBPX/4Go/tUl10mjc+LvHJABHUPOeLlFul9gNO9tJrHIuClYP3Tw==','2025-05-08 10:32:15.849199','STORE4_DEV4','2025-04-08 10:32:15.690676','2025-04-08 10:32:15.849205',false,false),
	 ('d1c81ca4-7b83-4bd3-998c-a6ce6f87f914'::uuid,'d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444'::uuid,'AQAAAAIAAYagAAAAECflozYIUqKKdzPD+MKZaLHWR4ew9TeVPNkSNjFnBongBH+4iJQ2nOMHNVY4FN+nMw==','2025-05-08 10:32:09.448916','STORE4_DEV2','2025-04-08 10:32:09.28926','2025-04-08 10:32:09.448922',false,false);
	 
INSERT INTO pos_device (device_id,store_id,hashed_token,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('a33cfc20-a4b2-46b2-a00b-1e71b23b1d6a'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEMY8sXfs5LUw2b3zEBeCtlKaLYmlZZymU22XRKKpy6yyCo92tWHeaoyrGumAT8sD5w==','2025-06-21 10:45:49.345','POS00000002','2025-04-22 00:02:47.321867','2025-05-22 10:45:49.345',false,false);

