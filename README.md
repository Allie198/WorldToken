# WorldToken

Geleneksel para birimleri enflasyonla boğuşurken tekil kripto paralara yapılan yatırımlar yüksek volatiliteye sahip olabiliyor
World Token'i tam da bu problemi çözmek için tasarladık 
Bizim yaratığımız bu token değerini hükümetlerin bastığı kağıt paralardan değil dünyanın en gözde ve en sağlam varlığından alan "Nihai Sepet"i yani Dünya Sepetini yarattık. Bu sepeti yaratırken Kripto dünyasının büyüme potansiyelini(BTC & ETH) ve Altın'ın binlerce yılda oluşmuş sarsılmaz güvenini tek bir tokende birleştirmeyi amaçladık.
Aynı zamanda projemiz defi alanına uygun hem riski seven hem de global bir para birimi olarak kullanılabilecek kadar katı bir token yapmak için sert varlıklar standardına uygun olarak geliştirilmiştir.

WLD Token değerini eşit oranlarda Altın ETH ve BTC değerlerinin 20000'e bölünmesiyle alır böylece istikrarı korurken herkes tarafından ulaşılır olmayı da sağlamış olur 

Projemiz OpenZeppelin gibi dış kütüphanelere hiç bağımlı kalmadan tasarlandı. ERC-20 standartlarına uyumlu bir yapı tasarlamaya çalıştık.
 - WorldToken.sol dosyası, sadece yetkili sistemin para basabildiği bir ERC-20 uyumlu token kontratı olarak çalışıyor. Bu kontrat, temel token işlevlerini basitçe yönetiyor.
 - System.sol ise Oracle entegrasyonuyla birlikte Chainlink üzerinden ETH, BTC ve XAU (Altın) fiyatlarını saniyelik olarak çekip fiyat verilerini sürekli güncelliyoruz.

![Image](https://github.com/user-attachments/assets/e38f9f0c-0777-4d72-8386-bb4d7868704c)
