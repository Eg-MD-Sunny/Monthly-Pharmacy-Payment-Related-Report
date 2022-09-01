-----|| 1st Part
-----|| Name: Full Month Order Related Data


select s.orderid OrderId,
       s.shipmentTag,
	   st.name [Store],
	   cast(dbo.tobdt(o.CreatedOnUtc)as smalldatetime)[CreatedOn],
	   s.reconciledon Reconciledon,
	   sum(tr.saleprice) Ordervalue,
	   dbo.GetEnumName('ShipmentStatus',ShipmentStatus) ShipmentStatus,
	   s.deliveryFee [DeliveryFee]
	   

from Shipment s
join thingrequest tr on tr.shipmentid=s.id
join [order] o on o.id=s.OrderId
join store st on st.id = o.storeId
join ProductVariant pv on pv.id = tr.ProductVariantId

where cast(dbo.tobdt(o.CreatedOnUtc)as date) >='2022-08-01'
and cast(dbo.tobdt(o.CreatedOnUtc)as date) <'2022-09-01'
and pv.distributionNetworkId = 2


group by  s.orderid,
          s.shipmentTag,
	      st.name,
	      cast(dbo.tobdt(o.CreatedOnUtc)as smalldatetime),
	      s.reconciledon,
		  dbo.GetEnumName('ShipmentStatus',ShipmentStatus),
	      s.deliveryFee 



-----|| 2nd Part
-----|| Name: Pharmacy Payment Related Data

--Bkash (Status=1)-Success
select  s.orderid,
		s.shipmentTag,
		pb.BkashTxId BkashTransactionID,
		'Bkash'[PaymentMethod]
		

FROM payment.PaymentInvoiceMap pmap
join payment.BkashPayment pb on pb.id=pmap.bkashpaymentid
join customer c on c.customerguid = pb.CreditAccount
left join shipment s on s.InvoiceId=pmap.InvoiceId
left join [Order] o on o.id = s.orderId

where cast(dbo.tobdt(o.CreatedOnUtc)as date)>='2022-08-01'
and cast(dbo.tobdt(o.CreatedOnUtc)as date)<'2022-09-01' 
and o.Id in ()

and Amount is not null
and Status in  (1)

group by s.orderid,
		 s.shipmentTag,
		 pb.BkashTxId 



-- Nogod 
select  s.orderid,
		s.shipmentTag,
		'Nogod'[PaymentMethod]
		

FROM payment.PaymentInvoiceMap pmap
join payment.NagadPayment pb on pb.id=pmap.NagadPaymentid
join customer c on c.customerguid = pb.CreditAccount
left join shipment s on s.InvoiceId=pmap.InvoiceId
left join [Order] o on o.id = s.orderId

where cast(dbo.tobdt(o.CreatedOnUtc)as date)>='2022-08-01'
and cast(dbo.tobdt(o.CreatedOnUtc)as date)<'2022-09-01'
and o.Id in ()

and Amount is not null
and Status in  (2)

group by s.orderid,
		 s.shipmentTag




-- Portwallet Payment
select  s.orderid OrderID,
		s.shipmentTag,
		pw.portwalletinvoiceid PortWalletInvoiceID, 'Portwallet'[PaymentMethod]

FROM shipment s
join payment.PaymentInvoiceMap pmap on pmap.InvoiceId = s.InvoiceId
join payment.PortwalletPayment pw on pw.id=pmap.portwalletpaymentid
join customer c on c.customerguid = pw.CreditAccount
join [Order] o on o.id = s.orderId
 
where cast(dbo.tobdt(o.CreatedOnUtc)as date)>='2022-08-01'
and cast(dbo.tobdt(o.CreatedOnUtc)as date)<'2022-09-01'

and o.Id in ()
and Amount is not null
and SucceededOn is not null

group by s.orderid ,
		s.shipmentTag,
		pw.portwalletinvoiceid



-- Braintree Payment
SELECT  s.orderid OrderID, 
		s.shipmentTag,
		bp.braintreeTxId BrainTreeTransactionID,
		'BrainTreeTransaction'[PaymentMethod]

FROM shipment s
join payment.PaymentInvoiceMap pmap on pmap.InvoiceId = s.InvoiceId
join [Payment].BraintreePayment  bp on bp.id=pmap.braintreepaymentid
join customer c on c.customerguid = bp.CreditAccount
join [Order] o on o.id = s.orderId

where cast(dbo.tobdt(o.CreatedOnUtc)as date)>='2022-08-01'
and cast(dbo.tobdt(o.CreatedOnUtc)as date)<'2022-09-01'
and o.Id in ()
and SettledOn is NOT NULL

group by s.orderid, 
		s.shipmentTag,
		bp.braintreeTxId 



-----|| 3rd Part
-----|| Name: Enlisted Pharmacy Product

select  pv.id [PVID],
		pv.Name [Product]

from ProductVariant pv
where pv.DistributionNetworkId = 2
and pv.Published =1
and pv.Deleted = 0